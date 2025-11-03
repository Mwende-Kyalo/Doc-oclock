package com.example.telemed.data.local

import androidx.room.Embedded
import androidx.room.Relation

data class AppointmentAndDoctor(
    @Embedded val appointment: Appointment,
    @Relation(
        parentColumn = "doctorId",
        entityColumn = "id"
    )
    val doctor: User
)