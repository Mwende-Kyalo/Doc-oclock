package com.example.telemed.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "doctor_availability")
data class DoctorAvailability(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val doctorId: Int,
    val date: String,
    val startTime: String,
    val endTime: String
)