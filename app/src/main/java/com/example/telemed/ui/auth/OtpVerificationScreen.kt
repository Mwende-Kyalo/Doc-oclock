package com.example.telemed.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.telemed.ui.theme.TelemedTheme

@Composable
fun OtpVerificationScreen(
    onVerifyClicked: (String) -> Unit,
    onResendClicked: () -> Unit
) {
    var otp by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Verify Your Email",
            style = MaterialTheme.typography.headlineLarge,
            color = MaterialTheme.colorScheme.primary
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Enter the OTP sent to your email address",
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(32.dp))

        OutlinedTextField(
            value = otp,
            onValueChange = { otp = it },
            label = { Text("OTP") },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(32.dp))

        Button(
            onClick = { onVerifyClicked(otp) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Verify")
        }

        Spacer(modifier = Modifier.height(16.dp))

        TextButton(onClick = onResendClicked) {
            Text("Resend OTP")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun OtpVerificationScreenPreview() {
    TelemedTheme {
        OtpVerificationScreen(onVerifyClicked = {}, onResendClicked = {})
    }
}
