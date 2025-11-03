package com.example.telemed.viewmodel

import android.app.Application
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import com.example.telemed.data.local.ChatMessage
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class ChatViewModel(application: Application, savedStateHandle: SavedStateHandle) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    private val appointmentId: Int = checkNotNull(savedStateHandle["appointmentId"])
    // This is a placeholder for the actual user ID
    private val senderId = 1 

    val messages = db.chatMessageDao().getMessagesForAppointment(appointmentId)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    var messageText by mutableStateOf("")

    fun sendMessage(receiverId: Int) {
        viewModelScope.launch {
            db.chatMessageDao().insertMessage(
                ChatMessage(
                    appointmentId = appointmentId,
                    senderId = senderId,
                    receiverId = receiverId,
                    message = messageText,
                    timestamp = System.currentTimeMillis()
                )
            )
            messageText = ""
        }
    }
}
