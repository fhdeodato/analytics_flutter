// Autogenerated from Pigeon (v7.2.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon


import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

private fun wrapResult(result: Any?): List<Any?> {
  return listOf(result)
}

private fun wrapError(exception: Throwable): List<Any> {
  return listOf<Any>(
    exception.javaClass.simpleName,
    exception.toString(),
    "Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)
  )
}

/** Generated class from Pigeon that represents data sent in messages. */
data class NativeContext (
  val app: NativeContextApp? = null,
  val device: NativeContextDevice? = null,
  val library: NativeContextLibrary? = null,
  val locale: String? = null,
  val network: NativeContextNetwork? = null,
  val os: NativeContextOS? = null,
  val screen: NativeContextScreen? = null,
  val timezone: String? = null,
  val userAgent: String? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): NativeContext {
      val app: NativeContextApp? = (list[0] as? List<Any?>)?.let {
        NativeContextApp.fromList(it)
      }
      val device: NativeContextDevice? = (list[1] as? List<Any?>)?.let {
        NativeContextDevice.fromList(it)
      }
      val library: NativeContextLibrary? = (list[2] as? List<Any?>)?.let {
        NativeContextLibrary.fromList(it)
      }
      val locale = list[3] as? String
      val network: NativeContextNetwork? = (list[4] as? List<Any?>)?.let {
        NativeContextNetwork.fromList(it)
      }
      val os: NativeContextOS? = (list[5] as? List<Any?>)?.let {
        NativeContextOS.fromList(it)
      }
      val screen: NativeContextScreen? = (list[6] as? List<Any?>)?.let {
        NativeContextScreen.fromList(it)
      }
      val timezone = list[7] as? String
      val userAgent = list[8] as? String
      return NativeContext(app, device, library, locale, network, os, screen, timezone, userAgent)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      app?.toList(),
      device?.toList(),
      library?.toList(),
      locale,
      network?.toList(),
      os?.toList(),
      screen?.toList(),
      timezone,
      userAgent,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class NativeContextApp (
  val build: String? = null,
  val name: String? = null,
  val namespace: String? = null,
  val version: String? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): NativeContextApp {
      val build = list[0] as? String
      val name = list[1] as? String
      val namespace = list[2] as? String
      val version = list[3] as? String
      return NativeContextApp(build, name, namespace, version)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      build,
      name,
      namespace,
      version,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class NativeContextDevice (
  val id: String? = null,
  val manufacturer: String? = null,
  val model: String? = null,
  val name: String? = null,
  val type: String? = null,
  val adTrackingEnabled: Boolean? = null,
  val advertisingId: String? = null,
  val trackingStatus: String? = null,
  val token: String? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): NativeContextDevice {
      val id = list[0] as? String
      val manufacturer = list[1] as? String
      val model = list[2] as? String
      val name = list[3] as? String
      val type = list[4] as? String
      val adTrackingEnabled = list[5] as? Boolean
      val advertisingId = list[6] as? String
      val trackingStatus = list[7] as? String
      val token = list[8] as? String
      return NativeContextDevice(id, manufacturer, model, name, type, adTrackingEnabled, advertisingId, trackingStatus, token)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      id,
      manufacturer,
      model,
      name,
      type,
      adTrackingEnabled,
      advertisingId,
      trackingStatus,
      token,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class NativeContextLibrary (
  val name: String? = null,
  val version: String? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): NativeContextLibrary {
      val name = list[0] as? String
      val version = list[1] as? String
      return NativeContextLibrary(name, version)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      name,
      version,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class NativeContextOS (
  val name: String? = null,
  val version: String? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): NativeContextOS {
      val name = list[0] as? String
      val version = list[1] as? String
      return NativeContextOS(name, version)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      name,
      version,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class NativeContextNetwork (
  val cellular: Boolean? = null,
  val wifi: Boolean? = null,
  val bluetooth: Boolean? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): NativeContextNetwork {
      val cellular = list[0] as? Boolean
      val wifi = list[1] as? Boolean
      val bluetooth = list[2] as? Boolean
      return NativeContextNetwork(cellular, wifi, bluetooth)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      cellular,
      wifi,
      bluetooth,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class NativeContextScreen (
  val height: Long? = null,
  val width: Long? = null,
  val density: Double? = null

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): NativeContextScreen {
      val height = list[0].let { if (it is Int) it.toLong() else it as? Long }
      val width = list[1].let { if (it is Int) it.toLong() else it as? Long }
      val density = list[2] as? Double
      return NativeContextScreen(height, width, density)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      height,
      width,
      density,
    )
  }
}

@Suppress("UNCHECKED_CAST")
private object NativeContextApiCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      128.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeContext.fromList(it)
        }
      }
      129.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeContextApp.fromList(it)
        }
      }
      130.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeContextDevice.fromList(it)
        }
      }
      131.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeContextLibrary.fromList(it)
        }
      }
      132.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeContextNetwork.fromList(it)
        }
      }
      133.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeContextOS.fromList(it)
        }
      }
      134.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          NativeContextScreen.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is NativeContext -> {
        stream.write(128)
        writeValue(stream, value.toList())
      }
      is NativeContextApp -> {
        stream.write(129)
        writeValue(stream, value.toList())
      }
      is NativeContextDevice -> {
        stream.write(130)
        writeValue(stream, value.toList())
      }
      is NativeContextLibrary -> {
        stream.write(131)
        writeValue(stream, value.toList())
      }
      is NativeContextNetwork -> {
        stream.write(132)
        writeValue(stream, value.toList())
      }
      is NativeContextOS -> {
        stream.write(133)
        writeValue(stream, value.toList())
      }
      is NativeContextScreen -> {
        stream.write(134)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated interface from Pigeon that represents a handler of messages from Flutter. */
interface NativeContextApi {
  fun getContext(collectDeviceId: Boolean, callback: (Result<NativeContext>) -> Unit)

  companion object {
    /** The codec used by NativeContextApi. */
    val codec: MessageCodec<Any?> by lazy {
      NativeContextApiCodec
    }
    /** Sets up an instance of `NativeContextApi` to handle messages through the `binaryMessenger`. */
    @Suppress("UNCHECKED_CAST")
    fun setUp(binaryMessenger: BinaryMessenger, api: NativeContextApi?) {
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.NativeContextApi.getContext", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            var wrapped = listOf<Any?>()
            val args = message as List<Any?>
            val collectDeviceIdArg = args[0] as Boolean
            api.getContext(collectDeviceIdArg) { result: Result<NativeContext> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                val data = result.getOrNull()
                reply.reply(wrapResult(data))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
    }
  }
}