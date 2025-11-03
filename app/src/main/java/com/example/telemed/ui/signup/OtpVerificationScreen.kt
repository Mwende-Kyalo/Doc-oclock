package com.example.telemed.ui.signup

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.telemed.ui.theme.TelemedTheme

@Composable
fun OtpVerificationScreen(onVerify: (String) -> Unit) {
    var otp by remember { mutableStateOf("") }
    val futuristicGradient = Brush.verticalGradient(listOf(Color(0xFF000428), Color(0xFF004e92)))

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(futuristicGradient),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(32.dp)
        ) {
            Text("Enter OTP", style = MaterialTheme.typography.headlineMedium, color = Color.White)
            Spacer(modifier = Modifier.height(16.dp))
            OutlinedTextField(value = otp, onValueChange = { otp = it }, label = { Text("OTP") })
            Spacer(modifier = Modifier.height(16.dp))
            Button(onClick = { onVerify(otp) }) {
                Text("Verify")
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun OtpVerificationScreenPreview() {
    TelemedTheme {
        OtpVerificationScreen(onVerify = {})
    }
}