package com.example.telemed.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface ChatMessageDao {
    @Insert
    suspend fun insertMessage(message: ChatMessage)

    @Query("SELECT * FROM chat_messages WHERE appointmentId = :appointmentId ORDER BY timestamp ASC")
    fun getMessagesForAppointment(appointmentId: Int): Flow<List<ChatMessage>>
}