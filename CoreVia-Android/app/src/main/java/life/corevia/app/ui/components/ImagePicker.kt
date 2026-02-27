package life.corevia.app.ui.components

import android.graphics.Bitmap
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import life.corevia.app.ui.theme.CoreViaPrimary
import java.io.File

/**
 * iOS CameraPicker.swift + ImagePicker.swift equivalent
 * Camera və Gallery picker-lər birləşdirilmiş
 */

@Composable
fun ImagePickerButtons(
    onImageSelected: (Bitmap) -> Unit,
    modifier: Modifier = Modifier,
    buttonColor: Color = CoreViaPrimary
) {
    val context = LocalContext.current
    var cameraUri by remember { mutableStateOf<Uri?>(null) }

    // Gallery launcher
    val galleryLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let {
            try {
                val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    ImageDecoder.decodeBitmap(ImageDecoder.createSource(context.contentResolver, it))
                } else {
                    @Suppress("DEPRECATION")
                    MediaStore.Images.Media.getBitmap(context.contentResolver, it)
                }
                onImageSelected(bitmap)
            } catch (_: Exception) {}
        }
    }

    // Camera launcher
    val cameraLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.TakePicture()
    ) { success ->
        if (success) {
            cameraUri?.let { uri ->
                try {
                    val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        ImageDecoder.decodeBitmap(ImageDecoder.createSource(context.contentResolver, uri))
                    } else {
                        @Suppress("DEPRECATION")
                        MediaStore.Images.Media.getBitmap(context.contentResolver, uri)
                    }
                    onImageSelected(bitmap)
                } catch (_: Exception) {}
            }
        }
    }

    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Camera button
        Box(
            modifier = Modifier
                .weight(1f)
                .clip(RoundedCornerShape(12.dp))
                .background(buttonColor.copy(alpha = 0.08f))
                .border(1.dp, buttonColor.copy(alpha = 0.2f), RoundedCornerShape(12.dp))
                .clickable {
                    val file = File.createTempFile("camera_", ".jpg", context.cacheDir)
                    val uri = FileProvider.getUriForFile(
                        context,
                        "${context.packageName}.provider",
                        file
                    )
                    cameraUri = uri
                    cameraLauncher.launch(uri)
                }
                .padding(vertical = 14.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.CameraAlt, null,
                    modifier = Modifier.size(20.dp),
                    tint = buttonColor
                )
                Text(
                    text = "Kamera",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = buttonColor
                )
            }
        }

        // Gallery button
        Box(
            modifier = Modifier
                .weight(1f)
                .clip(RoundedCornerShape(12.dp))
                .background(buttonColor.copy(alpha = 0.08f))
                .border(1.dp, buttonColor.copy(alpha = 0.2f), RoundedCornerShape(12.dp))
                .clickable {
                    galleryLauncher.launch("image/*")
                }
                .padding(vertical = 14.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Filled.PhotoLibrary, null,
                    modifier = Modifier.size(20.dp),
                    tint = buttonColor
                )
                Text(
                    text = "Qalereya",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = buttonColor
                )
            }
        }
    }
}
