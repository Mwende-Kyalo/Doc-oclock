package com.example.telemed.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import com.example.telemed.data.local.Appointment
import com.example.telemed.data.local.AppointmentAndDoctor
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class ViewAppointmentsViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    // This is a placeholder for the actual patient ID
    private val patientId = 1

    val appointments = db.appointmentDao().getAppointmentsForPatient(patientId)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList<AppointmentAndDoctor>())

    fun deleteAppointment(appointment: Appointment) {
        viewModelScope.launch {
            db.appointmentDao().deleteAppointment(appointment)
        }
    }

    fun updateAppointment(appointment: Appointment) {
        viewModelScope.launch {
            db.appointmentDao().updateAppointment(appointment)
        }
    }
}
