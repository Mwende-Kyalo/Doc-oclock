package com.example.telemed.viewmodel

import android.app.Application
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class SignInViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    var email by mutableStateOf("")
    var password by mutableStateOf("")

    private val _signInState = MutableStateFlow<SignInState>(SignInState.Idle)
    val signInState: StateFlow<SignInState> = _signInState

    fun onSignInClicked() {
        viewModelScope.launch {
            _signInState.value = SignInState.Loading
            val user = db.userDao().getUserByEmail(email)
            if (user == null) {
                _signInState.value = SignInState.Error("User not found")
                return@launch
            }
            // In a real app, you would use a proper password hashing library like BCrypt
            if (user.passwordHash != password) { 
                _signInState.value = SignInState.Error("Invalid password")
                return@launch
            }
            _signInState.value = SignInState.Success(user.role)
        }
    }
}

sealed class SignInState {
    object Idle : SignInState()
    object Loading : SignInState()
    data class Success(val role: String) : SignInState()
    data class Error(val message: String) : SignInState()
}
