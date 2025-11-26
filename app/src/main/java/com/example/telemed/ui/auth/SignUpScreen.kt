package com.example.telemed.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.telemed.ui.theme.TelemedTheme

@Composable
fun SignUpScreen(
    onSignUpClicked: (String, String, String, String, String) -> Unit,
    onLoginClicked: () -> Unit
) {
    var fullName by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var phoneNumber by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var userRole by remember { mutableStateOf<UserRole?>(null) }

    var emailError by remember { mutableStateOf<String?>(null) }
    var passwordError by remember { mutableStateOf<String?>(null) }
    var confirmPasswordError by remember { mutableStateOf<String?>(null) }

    val roles = UserRole.entries

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Create Account",
            style = MaterialTheme.typography.headlineLarge,
            color = MaterialTheme.colorScheme.primary
        )
        Spacer(modifier = Modifier.height(32.dp))

        OutlinedTextField(
            value = fullName,
            onValueChange = { fullName = it },
            label = { Text("Full Names") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = email,
            onValueChange = {
                email = it
                emailError = if (!android.util.Patterns.EMAIL_ADDRESS.matcher(it).matches()) {
                    "Invalid email format"
                } else {
                    null
                }
            },
            label = { Text("Email") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
            isError = emailError != null,
            modifier = Modifier.fillMaxWidth()
        )
        if (emailError != null) {
            Text(text = emailError!!, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
        }
        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = phoneNumber,
            onValueChange = { phoneNumber = it },
            label = { Text("Phone Number") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(16.dp))

        PasswordTextField(
            value = password,
            onValueChange = {
                password = it
                passwordError = validatePassword(it)
            },
            label = "Password",
            isError = passwordError != null
        )
        if (passwordError != null) {
            Text(text = passwordError!!, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
        }

        Spacer(modifier = Modifier.height(16.dp))

        PasswordTextField(
            value = confirmPassword,
            onValueChange = {
                confirmPassword = it
                confirmPasswordError = if (it != password) "Passwords do not match" else null
            },
            label = "Confirm Password",
            isError = confirmPasswordError != null
        )
        if (confirmPasswordError != null) {
            Text(text = confirmPasswordError!!, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
        }

        Spacer(modifier = Modifier.height(16.dp))

        Text("Select Role:", style = MaterialTheme.typography.bodyLarge)
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
            roles.forEach { role ->
                Row(verticalAlignment = Alignment.CenterVertically) {
                    RadioButton(
                        selected = userRole == role,
                        onClick = { userRole = role }
                    )
                    Text(text = role.name)
                }
            }
        }

        Spacer(modifier = Modifier.height(32.dp))

        Button(
            onClick = {
                if (emailError == null && passwordError == null && confirmPasswordError == null && userRole != null) {
                    onSignUpClicked(fullName, email, phoneNumber, userRole!!.name, password)
                }
            },
            modifier = Modifier.fillMaxWidth(),
            enabled = emailError == null && passwordError == null && confirmPasswordError == null && userRole != null
        ) {
            Text("Sign Up")
        }

        Spacer(modifier = Modifier.height(16.dp))
        TextButton(onClick = onLoginClicked) {
            Text("Already have an account? Log in")
        }
    }
}

@Composable
fun PasswordTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    isError: Boolean
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        visualTransformation = PasswordVisualTransformation(),
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
        isError = isError,
        modifier = Modifier.fillMaxWidth()
    )
}

fun validatePassword(password: String): String? {
    if (password.length < 8) {
        return "Password must be at least 8 characters long."
    }
    if (!password.contains(Regex("[A-Z]"))) {
        return "Password must contain an uppercase letter."
    }
    if (!password.contains(Regex("[a-z]"))) {
        return "Password must contain a lowercase letter."
    }
    if (!password.contains(Regex("[0-9]"))) {
        return "Password must contain a number."
    }
    if (!password.contains(Regex("[^A-Za-z0-9]"))) {
        return "Password must contain a special character."
    }
    return null
}

enum class UserRole {
    Doctor, Client, Admin
}

@Preview(showBackground = true)
@Composable
fun SignUpScreenPreview() {
    TelemedTheme {
        SignUpScreen(onSignUpClicked = { _, _, _, _, _ -> }, onLoginClicked = {})
    }
}
