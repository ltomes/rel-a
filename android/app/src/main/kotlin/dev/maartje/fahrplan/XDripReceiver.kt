package dev.maartje.fahrplan

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import java.net.URL
import android.util.Log
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection


class XDripSGVReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_GENERIC_WEATHER = "nodomain.freeyourgadget.gadgetbridge.ACTION_GENERIC_WEATHER"
        const val XDRIP_JSON = "XdripSGVJson"
        const val PREFS_NAME = "FlutterSharedPreferences"
        const val TAG = "XDripSGVReceiver"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent != null && ACTION_GENERIC_WEATHER == intent.action) {
            getXDripDataFromServer(context) { jsonData ->
                if (jsonData != null) {
                    saveXDripData(context, jsonData)
                } else {
                    Log.e(TAG, "Failed to retrieve XDrip data from server")
                }
            }
        }
    }

    /* This method should contact a server to pull a json file, The server does not have any
       authentication. The server expects a get request.
       Some documentation on the api:
       https://github.com/xdrip/xdrip_docs/blob/27ac415ff68d9c128f57063e4adfef3589a3a02c/docs/use/interapp.md?plain=1#L105
    */
    private fun getXDripDataFromServer(context: Context?, completion: (String?) -> Unit) {
        val url = URL("http://127.0.0.1:17580/sgv.json")

        val urlConnection: HttpURLConnection = url.openConnection() as HttpURLConnection
        urlConnection.connectTimeout = 3000

        if (urlConnection.responseCode >= 400) {
            completion("Error fetching data from server")
            urlConnection.disconnect()
            return
        }
        val reader: BufferedReader = BufferedReader(InputStreamReader(urlConnection.inputStream))
        var line: String? = null
        val stringBuilder: StringBuilder = StringBuilder()

        while (true) {
            line = reader.readLine()
            if (line == null) break

            stringBuilder.append(line)
        }

        completion(stringBuilder.toString())

        urlConnection.disconnect()
    }

    private fun saveXDripData(context: Context?, jsonData: String) {
        if (context != null) {
            val sharedPreferences: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putString("flutter." + XDRIP_JSON, jsonData)
            editor.apply()

            Log.d(TAG, "XDrip data saved")
            // log shared preferences data
            val allEntries: Map<String, *> = sharedPreferences.all
            for ((key, value) in allEntries) {
                Log.d(TAG, "$key: $value")
            }
        } else {
            Log.e(TAG, "Context is null, cannot save xDrip data")
        }
    }
}
