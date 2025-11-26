package com.example.telemed.viewmodel

import android.app.Application
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import com.example.telemed.data.local.User
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class SettingsViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    // This is a placeholder for the actual user ID
    private val userId = 1

    val user = db.userDao().getUserById(userId)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    var fullName by mutableStateOf("")
    var email by mutableStateOf("")
    var phoneNumber by mutableStateOf("")

    var isDarkMode by mutableStateOf(false)
    var isLargeFont by mutableStateOf(false)
    var isDyslexiaFriendly by mutableStateOf(false)
    var isTextToSpeechEnabled by mutableStateOf(false)

    init {
        viewModelScope.launch {
            val currentUser = user.first()
            currentUser?.let {
                fullName = it.fullName
                email = it.email
                phoneNumber = it.phoneNumber
            }
        }
    }

    fun onSaveChangesClicked() {
        viewModelScope.launch {
            val currentUser = user.first()
            currentUser?.let {
                val updatedUser = it.copy(
                    fullName = fullName,
                    email = email,
                    phoneNumber = phoneNumber
                )
                db.userDao().updateUser(updatedUser)
            }
        }
    }
}
