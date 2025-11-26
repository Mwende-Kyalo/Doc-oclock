package com.example.telemed.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "e_prescriptions")
data class EPrescription(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val patientId: Int,
    val doctorName: String,
    val date: String,
    val medication: String,
    val dosage: String,
    val frequency: String
)