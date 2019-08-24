package study.com.flutter_receiver_twilo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.telephony.SmsMessage

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(), SmsListener {

  val receiver: IncomingSmsBroadcastReceiver = IncomingSmsBroadcastReceiver()
  val CHANNEL = "flutter.native/sms_receiver"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)


    receiver.listener = this
    registerReceiver(receiver, IntentFilter("android.provider.Telephony.SMS_RECEIVED"))
  }

  override fun receive(message: String, address: String){
    callPlatformChannel(message, address)
  }

  override fun onDestroy() {
    super.onDestroy()
    unregisterReceiver(receiver)
  }

  class IncomingSmsBroadcastReceiver : BroadcastReceiver() {

    var listener: SmsListener? = null

    override fun onReceive(context: Context?, intent: Intent?) {
      val intentExtras = intent?.extras
      val sms = intentExtras?.get("pdus") as Array<Any>

      (0 until sms.size).forEach { i ->
        val format = intentExtras?.getString("format")
        var smsMessage: SmsMessage? = null

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
          smsMessage = SmsMessage.createFromPdu(sms[i] as ByteArray, format);
        } else {
          smsMessage = SmsMessage.createFromPdu(sms[i] as ByteArray);
        }

        var smsBody = smsMessage?.messageBody?.toString()
        var originalAddress = smsMessage?.originatingAddress?.toString()

        listener?.receive(smsBody!!, originalAddress!!)
      }

    }

  }

  fun callPlatformChannel(message: String, address: String){
    MethodChannel(flutterView, CHANNEL).invokeMethod(
            "messageReceived", "{\"address\": \"$address\", \"body\": \"$message\"}"
    );
  }

}

interface SmsListener {
  fun receive(message: String, address: String)
}


