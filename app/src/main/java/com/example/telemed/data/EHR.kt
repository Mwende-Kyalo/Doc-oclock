package com.example.telemed.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "ehr")
data class EHR(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val patientId: String,
    val doctorId: String,
    val date: Long, // Timestamp
    val diagnosis: String,
    val prescription: String,
    val notes: String
)
