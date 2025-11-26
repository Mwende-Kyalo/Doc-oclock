package com.example.telemed.viewmodel

import android.app.Application
import android.util.Patterns
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import com.example.telemed.data.local.User
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class SignUpViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    var fullName by mutableStateOf("")
    var email by mutableStateOf("")
    var phoneNumber by mutableStateOf("")
    var password by mutableStateOf("")
    var confirmPassword by mutableStateOf("")
    var role by mutableStateOf("Doctor")

    private val _signUpState = MutableStateFlow<SignUpState>(SignUpState.Idle)
    val signUpState: StateFlow<SignUpState> = _signUpState

    var emailError by mutableStateOf<String?>(null)
    var passwordError by mutableStateOf<String?>(null)
    var confirmPasswordError by mutableStateOf<String?>(null)

    private var otp: String? = null

    fun onSignUpClicked() {
        if (validateInput()) {
            // In a real app, you'd send an email with a real OTP
            otp = "123456"
            _signUpState.value = SignUpState.OtpVerification
        }
    }

    fun onOtpVerified(enteredOtp: String) {
        if (otp == enteredOtp) {
            viewModelScope.launch {
                db.userDao().insertUser(
                    User(
                        fullName = fullName,
                        email = email,
                        phoneNumber = phoneNumber,
                        role = role,
                        passwordHash = password // In a real app, hash the password
                    )
                )
                _signUpState.value = SignUpState.Success
            }
        } else {
            _signUpState.value = SignUpState.Error("Invalid OTP")
        }
    }

    private fun validateInput(): Boolean {
        var isValid = true

        if (!isEmailValid(email)) {
            emailError = "Invalid email format"
            isValid = false
        } else {
            emailError = null
        }

        if (!isPasswordValid(password)) {
            passwordError = "Password must be at least 8 characters long, contain a special character, a number, an uppercase and a lowercase letter."
            isValid = false
        } else {
            passwordError = null
        }

        if (password != confirmPassword) {
            confirmPasswordError = "Passwords do not match"
            isValid = false
        } else {
            confirmPasswordError = null
        }

        return isValid
    }

    private fun isEmailValid(email: String): Boolean {
        return Patterns.EMAIL_ADDRESS.matcher(email).matches()
    }

    private fun isPasswordValid(password: String): Boolean {
        if (password.length < 8) return false
        if (password.none { it.isDigit() }) return false
        if (password.none { it.isLowerCase() }) return false
        if (password.none { it.isUpperCase() }) return false
        val specialChars = "@#$%^&+=!"
        if (password.none { specialChars.contains(it) }) return false
        if (password.any { it.isWhitespace() }) return false
        return true
    }
}

sealed class SignUpState {
    object Idle : SignUpState()
    object OtpVerification : SignUpState()
    object Success : SignUpState()
    data class Error(val message: String) : SignUpState()
}
