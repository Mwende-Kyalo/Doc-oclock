package com.example.telemed.ui.signup

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
import androidx.navigation.NavController
import com.example.telemed.ui.theme.TelemedTheme
import com.example.telemed.viewmodel.SignUpState
import com.example.telemed.viewmodel.SignUpViewModel
import kotlinx.coroutines.delay

@Composable
fun SignUpScreen(navController: NavController) {
    if (LocalInspectionMode.current) {
        SignUpForm(
            fullName = "",
            onFullNameChange = {},
            email = "",
            onEmailChange = {},
            phoneNumber = "",
            onPhoneNumberChange = {},
            password = "",
            onPasswordChange = {},
            confirmPassword = "",
            onConfirmPasswordChange = {},
            role = "Doctor",
            onRoleChange = {},
            onSignUpClick = {},
            emailError = null,
            passwordError = null,
            confirmPasswordError = null,
            signUpState = SignUpState.Idle
        )
        return
    }

    val signUpViewModel: SignUpViewModel = viewModel()
    val signUpState by signUpViewModel.signUpState.collectAsState()

    when (signUpState) {
        is SignUpState.OtpVerification -> {
            OtpVerificationScreen(onVerify = { otp ->
                signUpViewModel.onOtpVerified(otp)
            })
        }
        is SignUpState.Success -> {
            LaunchedEffect(Unit) {
                delay(2000) // Show success message for 2 seconds
                navController.navigate("signin") {
                    popUpTo("signup") { inclusive = true }
                }
            }
            Box(
                modifier = Modifier.fillMaxSize().background(
                    Brush.verticalGradient(listOf(Color(0xFF000428), Color(0xFF004e92)))
                ),
                contentAlignment = Alignment.Center
            ) {
                Text("Account Created Successfully!", style = MaterialTheme.typography.headlineMedium, color = Color.White)
            }
        }
        else -> {
            SignUpForm(
                fullName = signUpViewModel.fullName,
                onFullNameChange = { signUpViewModel.fullName = it },
                email = signUpViewModel.email,
                onEmailChange = { signUpViewModel.email = it },
                phoneNumber = signUpViewModel.phoneNumber,
                onPhoneNumberChange = { signUpViewModel.phoneNumber = it },
                password = signUpViewModel.password,
                onPasswordChange = { signUpViewModel.password = it },
                confirmPassword = signUpViewModel.confirmPassword,
                onConfirmPasswordChange = { signUpViewModel.confirmPassword = it },
                role = signUpViewModel.role,
                onRoleChange = { signUpViewModel.role = it },
                onSignUpClick = { signUpViewModel.onSignUpClicked() },
                emailError = signUpViewModel.emailError,
                passwordError = signUpViewModel.passwordError,
                confirmPasswordError = signUpViewModel.confirmPasswordError,
                signUpState = signUpState
            )
        }
    }
}

@Composable
fun SignUpForm(
    fullName: String,
    onFullNameChange: (String) -> Unit,
    email: String,
    onEmailChange: (String) -> Unit,
    phoneNumber: String,
    onPhoneNumberChange: (String) -> Unit,
    password: String,
    onPasswordChange: (String) -> Unit,
    confirmPassword: String,
    onConfirmPasswordChange: (String) -> Unit,
    role: String,
    onRoleChange: (String) -> Unit,
    onSignUpClick: () -> Unit,
    emailError: String?,
    passwordError: String?,
    confirmPasswordError: String?,
    signUpState: SignUpState
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
                text = "Create Account",
                style = TextStyle(
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            )
            Spacer(modifier = Modifier.height(32.dp))

            if (signUpState is SignUpState.Error) {
                Text(signUpState.message, color = Color(0xFFE91E63))
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
                value = fullName,
                onValueChange = onFullNameChange,
                label = { Text("Full Name") },
                modifier = Modifier.fillMaxWidth(),
                colors = textFieldColors
            )
            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = email,
                onValueChange = onEmailChange,
                label = { Text("Email") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                isError = emailError != null,
                supportingText = { emailError?.let { Text(it) } },
                modifier = Modifier.fillMaxWidth(),
                colors = textFieldColors
            )
            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = phoneNumber,
                onValueChange = onPhoneNumberChange,
                label = { Text("Phone Number") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                modifier = Modifier.fillMaxWidth(),
                colors = textFieldColors
            )
            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = password,
                onValueChange = onPasswordChange,
                label = { Text("Password") },
                visualTransformation = PasswordVisualTransformation(),
                isError = passwordError != null,
                supportingText = { passwordError?.let { Text(it) } },
                modifier = Modifier.fillMaxWidth(),
                colors = textFieldColors
            )
            Spacer(modifier = Modifier.height(16.dp))

            OutlinedTextField(
                value = confirmPassword,
                onValueChange = onConfirmPasswordChange,
                label = { Text("Confirm Password") },
                visualTransformation = PasswordVisualTransformation(),
                isError = confirmPasswordError != null,
                supportingText = { confirmPasswordError?.let { Text(it) } },
                modifier = Modifier.fillMaxWidth(),
                colors = textFieldColors
            )
            Spacer(modifier = Modifier.height(24.dp))

            val roles = listOf("Doctor", "Patient")
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Center) {
                roles.forEach { r ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(
                            selected = (r == role),
                            onClick = { onRoleChange(r) },
                            colors = RadioButtonDefaults.colors(selectedColor = Color(0xFF00C6FF), unselectedColor = Color.Gray)
                        )
                        Text(text = r, color = Color.White, modifier = Modifier.padding(end = 16.dp))
                    }
                }
            }
            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = onSignUpClick,
                modifier = Modifier.fillMaxWidth().height(50.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF00C6FF)),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text("Sign Up", style = TextStyle(fontWeight = FontWeight.Bold, fontSize = 16.sp))
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun SignUpFormPreview() {
    TelemedTheme {
        SignUpForm(
            fullName = "",
            onFullNameChange = {},
            email = "",
            onEmailChange = {},
            phoneNumber = "",
            onPhoneNumberChange = {},
            password = "",
            onPasswordChange = {},
            confirmPassword = "",
            onConfirmPasswordChange = {},
            role = "Doctor",
            onRoleChange = {},
            onSignUpClick = {},
            emailError = null,
            passwordError = null,
            confirmPasswordError = null,
            signUpState = SignUpState.Idle
        )
    }
}