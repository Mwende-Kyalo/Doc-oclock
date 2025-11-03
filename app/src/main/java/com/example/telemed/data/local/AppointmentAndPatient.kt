package com.example.telemed.data.local

import androidx.room.Embedded
import androidx.room.Relation

data class AppointmentAndPatient(
    @Embedded val appointment: Appointment,
    @Relation(
        parentColumn = "patientId",
        entityColumn = "id"
    )
    val patient: User
)