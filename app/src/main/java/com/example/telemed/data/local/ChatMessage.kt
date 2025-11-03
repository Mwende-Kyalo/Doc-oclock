package com.example.telemed.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "chat_messages")
data class ChatMessage(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val appointmentId: Int,
    val senderId: Int,
    val receiverId: Int,
    val message: String,
    val timestamp: Long
)