package com.example.telemed.viewmodel

import android.app.Application
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import com.example.telemed.data.local.Appointment
import com.example.telemed.data.local.User
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class BookAppointmentViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    val doctors = db.userDao().getDoctors()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    var selectedDoctor by mutableStateOf<User?>(null)
    var selectedDate by mutableStateOf("")
    var selectedTime by mutableStateOf("")
    var consultationType by mutableStateOf("video")

    fun onBookAppointmentClicked(patientId: Int) {
        val doctor = selectedDoctor ?: return
        // Basic validation
        if (selectedDate.isNotBlank() && selectedTime.isNotBlank()) {
            viewModelScope.launch {
                db.appointmentDao().insertAppointment(
                    Appointment(
                        patientId = patientId,
                        doctorId = doctor.id,
                        appointmentDate = selectedDate,
                        appointmentTime = selectedTime,
                        consultationType = consultationType,
                        status = "booked"
                    )
                )
            }
        }
    }
}
