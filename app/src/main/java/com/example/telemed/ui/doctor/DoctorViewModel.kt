package com.example.telemed.ui.doctor

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.telemed.data.*
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class DoctorViewModel(
    private val appointmentDao: AppointmentDao,
    private val patientDao: PatientDao,
    private val ehrDao: EHRDao
) : ViewModel() {

    // In a real app, you would get the doctor's ID from the logged-in user
    private val doctorId = "doc1"

    val upcomingAppointments: StateFlow<List<Appointment>> = 
        appointmentDao.getUpcomingAppointmentsForDoctor(doctorId)
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun getPatient(patientId: String): StateFlow<Patient?> {
        return patientDao.getPatientById(patientId)
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)
    }

    fun getEHRForPatient(patientId: String): StateFlow<List<EHR>> {
        return ehrDao.getEHRForPatient(patientId)
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())
    }

    fun saveEHR(ehr: EHR) {
        viewModelScope.launch {
            ehrDao.insertOrUpdateEHR(ehr)
        }
    }
}
