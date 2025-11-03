package com.example.telemed.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface AppointmentDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAppointment(appointment: Appointment)

    @Update
    suspend fun updateAppointment(appointment: Appointment)

    @Delete
    suspend fun deleteAppointment(appointment: Appointment)

    @Transaction
    @Query("SELECT * FROM appointments WHERE patientId = :patientId")
    fun getAppointmentsForPatient(patientId: Int): Flow<List<AppointmentAndDoctor>>

    @Transaction
    @Query("SELECT * FROM appointments WHERE doctorId = :doctorId")
    fun getAppointmentsForDoctor(doctorId: Int): Flow<List<AppointmentAndPatient>>

    @Query("SELECT * FROM appointments")
    fun getAllAppointments(): Flow<List<Appointment>>
}