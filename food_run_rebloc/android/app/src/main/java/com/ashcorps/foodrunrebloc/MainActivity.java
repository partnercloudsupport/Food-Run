package com.ashcorps.foodrunrebloc;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "foodRun";

    @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if(call.method.equals("sendNumberToPhone")){
                  String phoneNumber = call.argument("phone_number");
                  String uri = "tel:" + phoneNumber.trim() ;
                  Intent intent = new Intent(Intent.ACTION_DIAL);
                  intent.setData(Uri.parse(uri));
                  startActivity(intent);
                }
                else if(call.method.equals("sendToMaps")){
                  String address = call.argument("address");
                  String uri = "geo:0,0?q=" + address.replace(" ","+");
                  String map = "http:/;/maps.google.co.in/maps?q=" + address;
                  Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(uri));
                  //intent.setPackage("com.google.android.apps.maps");
                  startActivity(intent);
                }
                else {
                  result.notImplemented();
                }
              }
            });

  }
}
