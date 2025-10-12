package com.example.telemed.ui.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.telemed.data.User
import com.example.telemed.data.UserDao
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class AuthViewModel(private val userDao: UserDao) : ViewModel() {

    private val _authState = MutableStateFlow<AuthState>(AuthState.Idle)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private var tempUser: User? = null
    private var otp: String? = null

    fun signUp(
        fullName: String,
        email: String,
        phoneNumber: String,
        role: String,
        password: String,
        confirmPassword: String
    ) {
        viewModelScope.launch {
            _authState.value = AuthState.Loading

            val emailError = if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) "Invalid email format" else null
            val passwordError = validatePassword(password)
            val confirmPasswordError = if (password != confirmPassword) "Passwords do not match" else null

            if (emailError != null || passwordError != null || confirmPasswordError != null) {
                _authState.value = AuthState.Error("Please fix the errors") 
                return@launch
            }

            // In a real app, you would hash the password here
            val passwordHash = password // Placeholder

            tempUser = User(fullName = fullName, email = email, phoneNumber = phoneNumber, role = role, passwordHash = passwordHash)

            // Simulate sending OTP
            otp = (1000..9999).random().toString()
            println("OTP for $email: $otp") // Log the OTP for now

            _authState.value = AuthState.OtpSent
        }
    }

    fun verifyOtpAndCreateUser(inputOtp: String) {
        viewModelScope.launch {
            if (inputOtp == otp && tempUser != null) {
                userDao.insertUser(tempUser!!)
                _authState.value = AuthState.Success
                tempUser = null
                otp = null
            } else {
                _authState.value = AuthState.Error("Invalid OTP")
            }
        }
    }

    fun signIn(email: String, password: String) {
        viewModelScope.launch {
            _authState.value = AuthState.Loading
            val user = userDao.getUserByEmail(email)

            // In a real app, you would verify the hashed password
            if (user != null && user.passwordHash == password) {
                _authState.value = AuthState.Success
            } else {
                _authState.value = AuthState.Error("Invalid email or password")
            }
        }
    }

    private fun validatePassword(password: String): String? {
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
}

sealed class AuthState {
    object Idle : AuthState()
    object Loading : AuthState()
    object OtpSent : AuthState()
    object Success : AuthState()
    data class Error(val message: String) : AuthState()
}
