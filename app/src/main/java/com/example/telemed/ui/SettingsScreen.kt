package com.example.telemed.ui

import android.widget.Toast
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.telemed.R
import com.example.telemed.data.local.User
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.SettingsViewModel

@Composable
fun SettingsScreen(settingsViewModel: SettingsViewModel = viewModel()) {
    val user by settingsViewModel.user.collectAsState()

    SettingsContent(
        user = user,
        fullName = settingsViewModel.fullName,
        onFullNameChange = { settingsViewModel.fullName = it },
        email = settingsViewModel.email,
        onEmailChange = { settingsViewModel.email = it },
        phoneNumber = settingsViewModel.phoneNumber,
        onPhoneNumberChange = { settingsViewModel.phoneNumber = it },
        isDarkMode = settingsViewModel.isDarkMode,
        onDarkModeChange = { settingsViewModel.isDarkMode = it },
        isLargeFont = settingsViewModel.isLargeFont,
        onLargeFontChange = { settingsViewModel.isLargeFont = it },
        isDyslexiaFriendly = settingsViewModel.isDyslexiaFriendly,
        onDyslexiaFriendlyChange = { settingsViewModel.isDyslexiaFriendly = it },
        isTextToSpeechEnabled = settingsViewModel.isTextToSpeechEnabled,
        onTextToSpeechChange = { settingsViewModel.isTextToSpeechEnabled = it },
        onSaveChangesClicked = { settingsViewModel.onSaveChangesClicked() }
    )
}

@Composable
fun SettingsContent(
    user: User?,
    fullName: String,
    onFullNameChange: (String) -> Unit,
    email: String,
    onEmailChange: (String) -> Unit,
    phoneNumber: String,
    onPhoneNumberChange: (String) -> Unit,
    isDarkMode: Boolean,
    onDarkModeChange: (Boolean) -> Unit,
    isLargeFont: Boolean,
    onLargeFontChange: (Boolean) -> Unit,
    isDyslexiaFriendly: Boolean,
    onDyslexiaFriendlyChange: (Boolean) -> Unit,
    isTextToSpeechEnabled: Boolean,
    onTextToSpeechChange: (Boolean) -> Unit,
    onSaveChangesClicked: () -> Unit
) {
    val context = LocalContext.current
    var isEditing by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        // Profile Picture
        Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            Image(
                painter = painterResource(id = R.drawable.ic_launcher_background),
                contentDescription = "Profile Picture",
                modifier = Modifier
                    .size(120.dp)
                    .clip(CircleShape)
                    .background(Color.Gray)
                    .clickable { /* TODO: Implement image picker */ },
                contentScale = ContentScale.Crop
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Account Details
        AccountDetails(isEditing, fullName, onFullNameChange, email, onEmailChange, phoneNumber, onPhoneNumberChange) { isEditing = !isEditing }

        Spacer(modifier = Modifier.height(16.dp))
        HorizontalDivider()
        Spacer(modifier = Modifier.height(16.dp))

        // Theme Preferences
        Text("Theme Preferences", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
        Row(verticalAlignment = Alignment.CenterVertically) {
            RadioButton(selected = !isDarkMode, onClick = { onDarkModeChange(false) })
            Text("Light Mode")
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            RadioButton(selected = isDarkMode, onClick = { onDarkModeChange(true) })
            Text("Dark Mode")
        }

        Spacer(modifier = Modifier.height(16.dp))
        HorizontalDivider()
        Spacer(modifier = Modifier.height(16.dp))

        // Usability Preferences
        Text("Usability Preferences", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(checked = isLargeFont, onCheckedChange = onLargeFontChange)
            Text("Large Fonts")
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(checked = isDyslexiaFriendly, onCheckedChange = onDyslexiaFriendlyChange)
            Text("Dyslexia-Friendly Font")
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(checked = isTextToSpeechEnabled, onCheckedChange = onTextToSpeechChange)
            Text("Text-to-Speech")
        }

        Spacer(modifier = Modifier.height(32.dp))

        // Save and Cancel Buttons
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
            OutlinedButton(onClick = { /* TODO: Implement cancel */ }) {
                Text("Cancel")
            }
            Spacer(modifier = Modifier.width(16.dp))
            Button(onClick = {
                onSaveChangesClicked()
                Toast.makeText(context, "Settings Saved!", Toast.LENGTH_SHORT).show()
            }) {
                Text("Save Changes")
            }
        }
    }
}

@Composable
fun AccountDetails(
    isEditing: Boolean,
    fullName: String,
    onFullNameChange: (String) -> Unit,
    email: String,
    onEmailChange: (String) -> Unit,
    phoneNumber: String,
    onPhoneNumberChange: (String) -> Unit,
    onEditClick: () -> Unit
) {
    Column {
        Text("Account Details", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(8.dp))
        if (isEditing) {
            OutlinedTextField(value = fullName, onValueChange = onFullNameChange, label = { Text("Full Name") }, modifier = Modifier.fillMaxWidth())
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(value = email, onValueChange = onEmailChange, label = { Text("Email") }, modifier = Modifier.fillMaxWidth())
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(value = phoneNumber, onValueChange = onPhoneNumberChange, label = { Text("Phone Number") }, modifier = Modifier.fillMaxWidth())
        } else {
            Text("Name: $fullName")
            Text("Email: $email")
            Text("Phone: $phoneNumber")
        }
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = onEditClick, modifier = Modifier.fillMaxWidth()) {
            Text(if (isEditing) "Done" else "Edit Account Details")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun SettingsScreenPreview() {
    TelemedTheme {
        SettingsContent(
            user = User(id = 1, fullName = "Mickey Mouse", email = "mickey@mouse.com", phoneNumber = "1234567890", role = "Patient", passwordHash = ""),
            fullName = "Mickey Mouse",
            onFullNameChange = {},
            email = "mickey@mouse.com",
            onEmailChange = {},
            phoneNumber = "1234567890",
            onPhoneNumberChange = {},
            isDarkMode = false,
            onDarkModeChange = {},
            isLargeFont = false,
            onLargeFontChange = {},
            isDyslexiaFriendly = false,
            onDyslexiaFriendlyChange = {},
            isTextToSpeechEnabled = false,
            onTextToSpeechChange = {},
            onSaveChangesClicked = {}
        )
    }
}