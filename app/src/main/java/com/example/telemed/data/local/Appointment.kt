package com.example.telemed.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "appointments")
data class Appointment(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val patientId: Int,
    val doctorId: Int,
    val appointmentDate: String,
    val appointmentTime: String,
    val consultationType: String, // "video" or "voice"
    val status: String // "booked", "completed", "cancelled"
)