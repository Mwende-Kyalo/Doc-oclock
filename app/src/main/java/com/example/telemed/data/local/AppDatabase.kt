package com.example.telemed.data.local

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [User::class, Appointment::class, MedicalHistory::class, EPrescription::class, DoctorAvailability::class, ChatMessage::class], version = 5, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {

    abstract fun userDao(): UserDao
    abstract fun appointmentDao(): AppointmentDao
    abstract fun medicalHistoryDao(): MedicalHistoryDao
    abstract fun ePrescriptionDao(): EPrescriptionDao
    abstract fun doctorAvailabilityDao(): DoctorAvailabilityDao
    abstract fun chatMessageDao(): ChatMessageDao
}