package vn.onlineoffice.www.oomessenger;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Bundle;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.firebase.FirebaseApp;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.CAMERA;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class MainActivity extends FlutterActivity {
  
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    if (!checkPermission()) {
      requestPermission();
    }
  }
  
	private boolean checkPermission() {
		int permissionReadExternalStorage = ContextCompat.checkSelfPermission(getApplicationContext(), READ_EXTERNAL_STORAGE);
		int permissionWriteExternalStorage = ContextCompat.checkSelfPermission(getApplicationContext(), WRITE_EXTERNAL_STORAGE);
		int permissionCamera = ContextCompat.checkSelfPermission(getApplicationContext(), CAMERA);
		return permissionReadExternalStorage == PackageManager.PERMISSION_GRANTED && permissionWriteExternalStorage == PackageManager.PERMISSION_GRANTED && permissionCamera == PackageManager.PERMISSION_GRANTED;
	}

	private void requestPermission() {
		ActivityCompat.requestPermissions(this, new String[]{ READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE, CAMERA}, 200);
	}
}