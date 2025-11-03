package com.example.telemed.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "medical_history")
data class MedicalHistory(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val patientId: Int,
    val condition: String,
    val date: String,
    val doctorName: String
)