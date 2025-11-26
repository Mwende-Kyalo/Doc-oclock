package com.example.telemed.data

import androidx.room.Entity
import androidx.room.PrimaryKey

enum class ConsultationMethod {
    AUDIO, VIDEO
}

@Entity(tableName = "appointments")
data class Appointment(
    @PrimaryKey val id: String,
    val patientId: String,
    val doctorId: String,
    val appointmentTime: Long, // Store as timestamp
    val consultationMethod: ConsultationMethod,
    val status: String // e.g., "Upcoming", "Completed", "Cancelled"
)
