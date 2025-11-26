package com.example.telemed.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import com.example.telemed.data.local.AppointmentAndPatient
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn

class PatientRecordsViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    // This is a placeholder for the actual doctor ID
    private val doctorId = 1

    val appointments = db.appointmentDao().getAppointmentsForDoctor(doctorId)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList<AppointmentAndPatient>())
}
