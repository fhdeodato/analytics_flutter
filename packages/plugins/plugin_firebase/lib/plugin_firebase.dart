library analytics_plugin_firebase;

import 'dart:convert';

import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/map_transform.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions, Firebase;

export 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions, Firebase;

import 'package:segment_analytics_plugin_firebase/properties.dart';

class FirebaseDestination extends DestinationPlugin {
  final Future<void> firebaseFuture;

  FirebaseDestination({FirebaseOptions? firebaseOptions, required String name})
      : firebaseFuture = firebaseOptions != null
            ? Firebase.initializeApp(
                name: name,
                options: firebaseOptions,
              )
            : Future.value(),
        super('Firebase');

  @override
  Future<RawEvent?> identify(IdentifyEvent event) async {
    if (event.userId != null) {
      await FirebaseAnalytics.instance.setUserId(id: event.userId!);
    }
    if (event.traits != null) {
      await Future.wait(event.traits!.toJson().entries.map((entry) async {
        await FirebaseAnalytics.instance
            .setUserProperty(name: entry.key, value: entry.value.toString());
      }));
    }
    return event;
  }

  @override
  Future<RawEvent?> track(TrackEvent event) async {
    await firebaseFuture;
    final properties = mapProperties(event.properties, mappings);

    List<AnalyticsEventItemJson> items = [];
    // first we copy the values from the items property
    if (properties.containsKey("items") && properties["items"] != null) {
      items = itemsFromJson(properties["items"]);

      // remvoe because there is no need to send it duplicated
      properties.remove("items");
    }

    // r emoving the 3DS property...
    if (properties.containsKey("3DS")) {
      properties.remove("3DS");
    }

    try {
      switch (event.event) {
        case 'Product Clicked':
          if (properties.containsKey('contentType') ||
              properties.containsKey('itemId')) {
            throw Exception("Missing properties: contentType and itemId");
          }

          await FirebaseAnalytics.instance.logSelectContent(
            contentType: properties['contentType'].toString(),
            itemId: properties['itemId'].toString(),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Product Viewed':
          await FirebaseAnalytics.instance.logViewItem(
            currency: properties["currency"]?.toString(),
            items: event.properties == null
                ? null
                : [AnalyticsEventItemJson(event.properties!)],
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Product Added':
          await FirebaseAnalytics.instance.logAddToCart(
            currency: properties["currency"]?.toString(),
            items: event.properties == null
                ? null
                : [AnalyticsEventItemJson(event.properties!)],
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Product Removed':
          await FirebaseAnalytics.instance.logRemoveFromCart(
            currency: properties["currency"]?.toString(),
            items: event.properties == null
                ? null
                : [AnalyticsEventItemJson(event.properties!)],
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Checkout Started':
          await FirebaseAnalytics.instance.logBeginCheckout(
            coupon: properties["coupon"]?.toString(),
            currency: properties["currency"]?.toString(),
            items: properties["items"] as List<AnalyticsEventItemJson>,
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Promotion Viewed':
          await FirebaseAnalytics.instance.logViewPromotion(
            creativeName: properties["creativeName"]?.toString(),
            creativeSlot: properties["creativeSlot"]?.toString(),
            items: properties["items"] as List<AnalyticsEventItemJson>,
            locationId: properties["locationdId"]?.toString(),
            promotionId: properties["promotionId"]?.toString(),
            promotionName: properties["promotionName"]?.toString(),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Payment Info Entered':
          await FirebaseAnalytics.instance.logAddPaymentInfo(
            coupon: properties["coupon"]?.toString(),
            currency: properties["currency"]?.toString(),
            items: properties["items"] as List<AnalyticsEventItemJson>,
            paymentType: properties["paymentType"]?.toString(),
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Order Completed':
          await FirebaseAnalytics.instance.logPurchase(
            affiliation: properties["affiliation"]?.toString(),
            coupon: properties["coupon"]?.toString(),
            currency: properties["currency"]?.toString(),
            items: properties["items"] as List<AnalyticsEventItemJson>,
            shipping: double.tryParse(properties["shipping"].toString()),
            tax: double.tryParse(properties["tax"].toString()),
            transactionId: properties["transactionId"]?.toString(),
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Order Refunded':
          await FirebaseAnalytics.instance.logRefund(
            affiliation: properties["affiliation"]?.toString(),
            coupon: properties["coupon"]?.toString(),
            currency: properties["currency"]?.toString(),
            items: properties["items"] as List<AnalyticsEventItemJson>,
            shipping: double.tryParse(properties["shipping"].toString()),
            tax: double.tryParse(properties["tax"].toString()),
            transactionId: properties["transactionId"]?.toString(),
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Product List Viewed':
          await FirebaseAnalytics.instance.logViewItemList(
            itemListId: properties["itemListId"]?.toString(),
            itemListName: properties["itemListName"]?.toString(),
            items: properties["items"] as List<AnalyticsEventItemJson>,
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Product Added to Wishlist':
          await FirebaseAnalytics.instance.logAddToWishlist(
            currency: properties["currency"]?.toString(),
            items: properties["items"] as List<AnalyticsEventItemJson>,
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Cart Shared':
          if (event.properties == null ||
              event.properties!['products'] == null) {
            log("Error tracking event '${event.event}' for Firebase: products property must be a list of products");
          } else if (event.properties!['products'] is List) {
            await Future.wait(
                (event.properties!['products'] as List).map((product) async {
              final productProperties = mapProperties(product, mappings);
              if (productProperties.containsKey("contentType") &&
                  productProperties.containsKey("itemId") &&
                  productProperties.containsKey("method")) {
                await FirebaseAnalytics.instance.logShare(
                  contentType: productProperties["contentType"].toString(),
                  itemId: productProperties["itemId"].toString(),
                  method: properties["method"].toString(),
                  parameters: castParameterType(properties, nullAsString: ""),
                );
              } else {
                log("Error tracking Cart Shared, product missing properties. Required: contentType, itemId, method");
              }
            }));
          } else {
            log("Error tracking event '${event.event}' for Firebase: products property must be a list of products");
          }
          break;
        case 'Product Shared':
          if (!properties.containsKey("contentType") ||
              !properties.containsKey("itemId") ||
              !properties.containsKey("method")) {
            throw Exception("Missing properties: contentType, itemId, method");
          }
          await FirebaseAnalytics.instance.logShare(
            contentType: properties["contentType"].toString(),
            itemId: properties["itemId"].toString(),
            method: properties["method"].toString(),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Products Searched':
          if (!properties.containsKey("searchTerm")) {
            throw Exception("Missing property: searchTerm");
          }

          await FirebaseAnalytics.instance.logSearch(
            searchTerm: properties["searchTerm"].toString(),
            destination: properties["destination"]?.toString(),
            endDate: properties["endDate"]?.toString(),
            numberOfNights:
                int.tryParse(properties["numberOfNights"].toString()),
            numberOfPassengers:
                int.tryParse(properties["numberOfPassengers"].toString()),
            numberOfRooms: int.tryParse(properties["numberOfRooms"].toString()),
            origin: properties["origin"]?.toString(),
            startDate: properties["startDate"]?.toString(),
            travelClass: properties["travelClass"]?.toString(),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        default:
          await FirebaseAnalytics.instance.logEvent(
              name: sanitizeEventName(event.event),
              parameters: castParameterType(properties, nullAsString: ""));
          break;
      }
    } catch (error) {
      log("Error tracking event '${event.event}' for Firebase: ${error.toString()}");
    }
    return event;
  }

  @override
  Future<RawEvent?> screen(ScreenEvent event) async {
    // lets check if there is a title inside the event.properties
    String name = event.properties?["title"] ?? event.name;
    String section = event.properties?["site_section"] ?? event.name;
    FirebaseAnalytics.instance
        .logScreenView(screenClass: event.name, screenName: event.name);
    return event;
  }

  @override
  void reset() {
    FirebaseAnalytics.instance.resetAnalyticsData();
  }
}
