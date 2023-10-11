from django.db import models
from django.utils import timezone

# Define your models here

class User(models.Model):
    """
    Represents a user of the application.
    """
    name = models.CharField(max_length=100)
    email = models.EmailField()
    password = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class Driver(models.Model):
    """
    Represents a driver in the application.
    """
    name = models.CharField(max_length=255, unique=True, blank=False, null=False)
    license_plate_number = models.CharField(max_length=255, unique=True, blank=False, null=False)
    created_at = models.DateTimeField(db_index=True, default=timezone.now, verbose_name="Created datetime")
    updated_at = models.DateTimeField(auto_now=True)
    availability = models.CharField(max_length=255, blank=False, null=False)
    is_busy = models.BooleanField(default=False)
    is_available = models.BooleanField(default=True)

    class Meta:
        db_table = "binary_database_files_driver"
        verbose_name = "Driver"
        verbose_name_plural = "Drivers"

    def __str__(self):
        return self.name

class DriverLicense(models.Model):
    """
    Represents a driver's license in the application.
    """
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    created_at = models.DateTimeField(db_index=True, default=timezone.now, verbose_name="Created datetime")
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "binary_database_files_driver_license"
        verbose_name = "Driver License"
        verbose_name_plural = "Driver Licenses"

    def __str__(self):
        return str(self.driver)

class Vehicle(models.Model):
    """
    Represents a vehicle in the application.
    """
    license_plate_number = models.CharField(max_length=255, unique=True, blank=False, null=False)
    make = models.CharField(max_length=255, blank=False, null=False)
    model = models.CharField(max_length=255, blank=False, null=False)
    year = models.DateField(blank=False, null=False)
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='vehicles')
    created_at = models.DateTimeField(db_index=True, default=timezone.now, verbose_name="Created datetime")
    updated_at = models.DateTimeField(auto_now=True)
    is_busy = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        super(Vehicle, self).save(*args, **kwargs)

    def __str__(self):
        return self.license_plate_number

    class Meta:
        db_table = "binary_database_files_vehicle"
        verbose_name = "Vehicle"
        verbose_name_plural = "Vehicles"

class VehicleLicense(models.Model):
    """
    Represents a vehicle license in the application.
    """
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE)
    created_at = models.DateTimeField(db_index=True, default=timezone.now, verbose_name="Created datetime")
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "binary_database_files_vehicle_license"
        verbose_name = "Vehicle License"
        verbose_name_plural = "Vehicle Licenses"
        unique_together = ('vehicle', 'created_at')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['created_at']),
        ]
        constraints = [
            models.UniqueConstraint(fields=['vehicle', 'created_at'], name='unique_vehicle_license'),
        ]

    def __str__(self):
        return str(self.vehicle)
    
class Ride(models.Model):
    """
    Represents a ride in the application.
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE)
    pickup_location = models.CharField(max_length=255)
    dropoff_location = models.CharField(max_length=255)
    fare = models.DecimalField(max_digits=10, decimal_places=2)
    status_choices = [
        ('requested', 'Requested'),
        ('accepted', 'Accepted'),
        ('completed', 'Completed'),
        ('canceled', 'Canceled'),
    ]
    status = models.CharField(max_length=10, choices=status_choices, default='requested')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Ride from {self.pickup_location} to {self.dropoff_location}"
