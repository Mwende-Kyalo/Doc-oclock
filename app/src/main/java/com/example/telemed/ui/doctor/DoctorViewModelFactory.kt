package com.example.telemed.ui.doctor

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.example.telemed.data.AppointmentDao
import com.example.telemed.data.EHRDao
import com.example.telemed.data.PatientDao

class DoctorViewModelFactory(
    private val appointmentDao: AppointmentDao,
    private val patientDao: PatientDao,
    private val ehrDao: EHRDao
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(DoctorViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return DoctorViewModel(appointmentDao, patientDao, ehrDao) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
