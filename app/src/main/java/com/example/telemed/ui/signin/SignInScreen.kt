package com.example.telemed.ui.signin

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalInspectionMode
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.SignInState
import com.example.telemed.viewmodel.SignInViewModel

@Composable
fun SignInScreen(
    onSignUpClicked: () -> Unit,
    onSignInSuccess: (String) -> Unit,
) {
    // This check prevents the ViewModel from being created in preview mode, which causes a crash.
    if (LocalInspectionMode.current) {
        SignInForm(
            email = "",
            onEmailChange = {},
            password = "",
            onPasswordChange = {},
            onSignInClick = {},
            onSignUpClick = {},
            signInState = SignInState.Idle
        )
        return
    }

    val signInViewModel: SignInViewModel = viewModel()
    val signInState by signInViewModel.signInState.collectAsState()

    if (signInState is SignInState.Success) {
        LaunchedEffect(signInState) {
            onSignInSuccess((signInState as SignInState.Success).role)
        }
    }

    SignInForm(
        email = signInViewModel.email,
        onEmailChange = { signInViewModel.email = it },
        password = signInViewModel.password,
        onPasswordChange = { signInViewModel.password = it },
        onSignInClick = { signInViewModel.onSignInClicked() },
        onSignUpClick = onSignUpClicked,
        signInState = signInState
    )
}

@Composable
fun SignInForm(
    email: String,
    onEmailChange: (String) -> Unit,
    password: String,
    onPasswordChange: (String) -> Unit,
    onSignInClick: () -> Unit,
    onSignUpClick: () -> Unit,
    signInState: SignInState
) {
    val futuristicGradient = Brush.verticalGradient(listOf(Color(0xFF000428), Color(0xFF004e92)))

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(futuristicGradient)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Sign In",
                style = TextStyle(
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            )
            Spacer(modifier = Modifier.height(32.dp))

            if (signInState is SignInState.Error) {
                Text(signInState.message, color = Color(0xFFE91E63))
                Spacer(modifier = Modifier.height(16.dp))
            }

            val textFieldColors = TextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White,
                focusedContainerColor = Color.Transparent,
                unfocusedContainerColor = Color.Transparent,
                cursorColor = Color.White,
                focusedIndicatorColor = Color.White,
                unfocusedIndicatorColor = Color.Gray,
                focusedLabelColor = Color.White,
                unfocusedLabelColor = Color.Gray
            )

            OutlinedTextField(
                value = email,
                onValueChange = onEmailChange,
                label = { Text("Email") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                modifier = Modifier.fillMaxWidth(),
                colors = textFieldColors
            )
            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = password,
                onValueChange = onPasswordChange,
                label = { Text("Password") },
                visualTransformation = PasswordVisualTransformation(),
                modifier = Modifier.fillMaxWidth(),
                colors = textFieldColors
            )
            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = onSignInClick,
                modifier = Modifier.fillMaxWidth().height(50.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF00C6FF)),
                shape = RoundedCornerShape(16.dp)
            ) {
                if (signInState is SignInState.Loading) {
                    CircularProgressIndicator(color = Color.White)
                } else {
                    Text("Sign In", style = TextStyle(fontWeight = FontWeight.Bold, fontSize = 16.sp))
                }
            }
            Spacer(modifier = Modifier.height(16.dp))

            TextButton(onClick = onSignUpClick) {
                Text("Don't have an account? Sign up", color = Color.White)
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun SignInScreenPreview() {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    TelemedTheme {
        SignInForm(
            email = email,
            onEmailChange = { email = it },
            password = password,
            onPasswordChange = { password = it },
            onSignInClick = {},
            onSignUpClick = {},
            signInState = SignInState.Idle
        )
    }
}