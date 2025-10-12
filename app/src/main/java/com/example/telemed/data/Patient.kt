package com.example.telemed.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "patients")
data class Patient(
    @PrimaryKey val id: String,
    val fullName: String,
    val profilePictureUrl: String? = null
)
