package com.example.telemed.data

import androidx.room.Dao
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface AppointmentDao {
    @Query("SELECT * FROM appointments WHERE doctorId = :doctorId AND status = 'Upcoming' ORDER BY appointmentTime ASC")
    fun getUpcomingAppointmentsForDoctor(doctorId: String): Flow<List<Appointment>>
}
