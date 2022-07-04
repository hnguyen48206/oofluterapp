package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.flutter_webview_plugin.FlutterWebviewPlugin;
import de.esys.esysfluttershare.EsysFlutterSharePlugin;
import com.mr.flutter.plugin.filepicker.FilePickerPlugin;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
import fr.g123k.flutterappbadger.FlutterAppBadgerPlugin;
import com.alveliu.flutterfullpdfviewer.FlutterFullPdfViewerPlugin;
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin;
import pt.tribeiro.flutter_plugin_pdf_viewer.FlutterPluginPdfViewerPlugin;
import de.gigadroid.flutterudid.FlutterUdidPlugin;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import io.flutter.plugins.localauth.LocalAuthPlugin;
import com.vitanov.multiimagepicker.MultiImagePickerPlugin;
import com.crazecoder.openfile.OpenFilePlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import io.flutter.plugins.urllauncher.UrlLauncherPlugin;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;
import creativecreatorormaybenot.wakelock.WakelockPlugin;
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    FlutterWebviewPlugin.registerWith(registry.registrarFor("com.flutter_webview_plugin.FlutterWebviewPlugin"));
    EsysFlutterSharePlugin.registerWith(registry.registrarFor("de.esys.esysfluttershare.EsysFlutterSharePlugin"));
    FilePickerPlugin.registerWith(registry.registrarFor("com.mr.flutter.plugin.filepicker.FilePickerPlugin"));
    FlutterFirebaseCorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
    FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
    FlutterAppBadgerPlugin.registerWith(registry.registrarFor("fr.g123k.flutterappbadger.FlutterAppBadgerPlugin"));
    FlutterFullPdfViewerPlugin.registerWith(registry.registrarFor("com.alveliu.flutterfullpdfviewer.FlutterFullPdfViewerPlugin"));
    FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
    FlutterAndroidLifecyclePlugin.registerWith(registry.registrarFor("io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
    FlutterPluginPdfViewerPlugin.registerWith(registry.registrarFor("pt.tribeiro.flutter_plugin_pdf_viewer.FlutterPluginPdfViewerPlugin"));
    FlutterUdidPlugin.registerWith(registry.registrarFor("de.gigadroid.flutterudid.FlutterUdidPlugin"));
    ImagePickerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
    LocalAuthPlugin.registerWith(registry.registrarFor("io.flutter.plugins.localauth.LocalAuthPlugin"));
    MultiImagePickerPlugin.registerWith(registry.registrarFor("com.vitanov.multiimagepicker.MultiImagePickerPlugin"));
    OpenFilePlugin.registerWith(registry.registrarFor("com.crazecoder.openfile.OpenFilePlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
    SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    UrlLauncherPlugin.registerWith(registry.registrarFor("io.flutter.plugins.urllauncher.UrlLauncherPlugin"));
    VideoPlayerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.videoplayer.VideoPlayerPlugin"));
    WakelockPlugin.registerWith(registry.registrarFor("creativecreatorormaybenot.wakelock.WakelockPlugin"));
    WebViewFlutterPlugin.registerWith(registry.registrarFor("io.flutter.plugins.webviewflutter.WebViewFlutterPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
