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
      // items = itemsFromJson(properties["items"]);

      // Convert the current product items
      int index = 0;
      for (var newItem in properties["items"] as List<dynamic>) {
        index++;
        items.add(AnalyticsEventItemJson(<String, dynamic>{
          if (newItem['product_id'] != null)
            'itemId': newItem['product_id'].toString(),
          if (newItem['name'] != null) 'itemName': newItem['name'].toString().toLowerCase(),
          // if (newItem['brand'] != null) 'affiliation': newItem['brand'].toString(),
          'affiliation': '',
          // if (newItem['discount_tier'] != null) 'coupon': newItem['discount_tier'].toString(),
          'coupon': '',
          if (newItem['product_discount_amount'] != null)
            'discount':
                double.tryParse(newItem['product_discount_amount'].toString()),
          'index': index,
          if (newItem['brand'] != null)
            'itemBrand': newItem['brand'].toString(),
          if (newItem['category'] != null)
            'itemCategory': newItem['category'].toString(),
          if (newItem['product_subcategory'] != null)
            'itemCategory2': newItem['product_subcategory'].toString(),
          if (newItem['condition'] != null)
            'itemCategory3': newItem['condition'].toString(),
          if (newItem['color'] != null)
            'itemCategory4': newItem['color'].toString(),
          if (newItem['product_subcategory'] != null)
            'itemCategory5': newItem['product_subcategory'].toString(),
          if (newItem['product_id'] != null)
            'itemListId': newItem['product_id'].toString(),
          if (newItem['brand'] != null)
            'itemListName': newItem['brand'].toString(),
          if (newItem['material'] != null)
            'itemVariant': newItem['material'].toString(),
          if (newItem['product_id'] != null)
            'locationId': newItem['product_id'].toString(),
          if (newItem['price'] != null)
            'price': double.tryParse(newItem['price'].toString()),
          if (newItem['quantity'] != null)
            'quantity': int.tryParse(newItem['quantity'].toString()),
          'parameters': newItem
        }));
      }

      // remvoe because there is no need to send it duplicated
      properties.remove("items");
    }

    // r emoving the 3DS property...
    if (properties.containsKey("3DS")) {
      properties.remove("3DS");
    }

    String currentCurrency = properties["currency"] != null
        ? properties["currency"].toString()
        : "USD";

    try {
      switch (event.event) {
        case 'Product Clicked':
          if (!(properties.containsKey('list_id') &&
              (properties.containsKey('name') ||
                  properties.containsKey('itemName')) &&
              properties.containsKey('itemId'))) {
            throw Exception(
                "Missing properties: list_name, list_id, name and itemID");
          }
          String name = (properties["name"] ??
                  properties["itemName"] ??
                  properties["itemId"])
              .toString().toLowerCase();
          AnalyticsEventItem analyticsEventItem = AnalyticsEventItem(
              itemName: name, itemId: properties['itemId'].toString());

          await FirebaseAnalytics.instance.logSelectItem(
            itemListName:
                (properties['list_name'] ?? properties['list_id']).toString(),
            itemListId: properties['list_id'].toString(),
            items: [analyticsEventItem],
          );
          break;
        case 'Product Viewed':

          // create the item to be sent correctly
          AnalyticsEventItem productViewed = AnalyticsEventItem(
            affiliation: properties["brand"].toString(),
            currency: properties["currency"].toString(),
            itemBrand: properties["brand"].toString(),
            itemName: properties["itemName"].toString().toLowerCase(),
            itemCategory: properties["item_category"].toString(),
            price: num.tryParse(properties["price"].toString()) ?? 0,
            itemId: properties["itemId"].toString(),
            quantity: 1,
          );

          await FirebaseAnalytics.instance.logViewItem(
            currency: currentCurrency,
            // items: event.properties == null ? null : [AnalyticsEventItemJson(event.properties!)],
            items: [productViewed],
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Product Added':
          // create the item to be sent correctly
          AnalyticsEventItem productAdded = AnalyticsEventItem(
            affiliation: properties["brand"].toString(),
            currency: properties["currency"].toString(),
            itemBrand: properties["brand"].toString(),
            itemName: properties["itemName"].toString().toLowerCase(),
            itemCategory: properties["item_category"].toString(),
            price: num.tryParse(properties["price"].toString()) ?? 0,
            itemId: properties["itemId"].toString(),
            quantity: 1,
          );
          await FirebaseAnalytics.instance.logAddToCart(
            currency: currentCurrency,
            // items: event.properties == null ? null : [AnalyticsEventItemJson(event.properties!)],
            items: [productAdded],
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Product Removed':
          AnalyticsEventItem productRemoved = AnalyticsEventItem(
            affiliation: properties["brand"].toString(),
            currency: properties["currency"].toString(),
            itemBrand: properties["brand"].toString(),
            itemName: properties["itemName"].toString().toLowerCase(),
            itemCategory: properties["item_category"].toString(),
            price: num.tryParse(properties["price"].toString()) ?? 0,
            itemId: properties["itemId"].toString(),
            quantity: 1,
          );

          await FirebaseAnalytics.instance.logRemoveFromCart(
            currency: currentCurrency,
            // items: event.properties == null ? null : [AnalyticsEventItemJson(event.properties!)],
            items: [productRemoved],
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Checkout Started':
          await FirebaseAnalytics.instance.logBeginCheckout(
            coupon: properties["coupon"]?.toString(),
            currency: currentCurrency,
            items: items,
            // items: properties["items"] as List<AnalyticsEventItemJson>,
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Promotion Viewed':
          await FirebaseAnalytics.instance.logViewPromotion(
            creativeName: properties["creativeName"]?.toString(),
            creativeSlot: properties["creativeSlot"]?.toString(),
            items: items,
            // items: properties["items"] as List<AnalyticsEventItemJson>,
            locationId: properties["locationdId"]?.toString(),
            promotionId: properties["promotionId"]?.toString(),
            promotionName: properties["promotionName"]?.toString(),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Payment Info Entered':
          await FirebaseAnalytics.instance.logAddPaymentInfo(
            coupon: properties["coupon"]?.toString(),
            currency: currentCurrency,
            items: items,
            // items: properties["items"] as List<AnalyticsEventItemJson>,
            paymentType: properties["paymentType"]?.toString(),
            value: double.tryParse(properties["value"].toString()),
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Order Completed':
          await FirebaseAnalytics.instance.logPurchase(
            affiliation: properties["affiliation"]?.toString(),
            coupon: properties["coupon"]?.toString(),
            currency: currentCurrency,
            items: items,
            // items: properties["items"] as List<AnalyticsEventItemJson>,
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
            currency: currentCurrency,
            items: items,
            // items: properties["items"] as List<AnalyticsEventItemJson>,
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
            items: items,
            // items: properties["items"] as List<AnalyticsEventItemJson>,
            parameters: castParameterType(properties, nullAsString: ""),
          );
          break;
        case 'Product Added to Wishlist':
          await FirebaseAnalytics.instance.logAddToWishlist(
            currency: currentCurrency,
            items: items,
            // items: properties["items"] as List<AnalyticsEventItemJson>,
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
        .logScreenView(screenClass: name, screenName: section);
    return event;
  }

  @override
  void reset() {
    FirebaseAnalytics.instance.resetAnalyticsData();
  }
}
