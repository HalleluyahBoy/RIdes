# Generated by Django 4.2.6 on 2023-10-07 14:58

from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Driver",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("name", models.CharField(max_length=255, unique=True)),
                ("license_plate_number", models.CharField(max_length=255, unique=True)),
                (
                    "created_at",
                    models.DateTimeField(
                        db_index=True,
                        default=django.utils.timezone.now,
                        verbose_name="Created datetime",
                    ),
                ),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("availability", models.CharField(max_length=255)),
                ("is_busy", models.BooleanField(default=False)),
                ("is_available", models.BooleanField(default=True)),
            ],
            options={
                "verbose_name": "Driver",
                "verbose_name_plural": "Drivers",
                "db_table": "binary_database_files_driver",
            },
        ),
        migrations.CreateModel(
            name="User",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("name", models.CharField(max_length=100)),
                ("email", models.EmailField(max_length=254)),
                ("password", models.CharField(max_length=100)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
            ],
        ),
        migrations.CreateModel(
            name="Vehicle",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("license_plate_number", models.CharField(max_length=255, unique=True)),
                ("make", models.CharField(max_length=255)),
                ("model", models.CharField(max_length=255)),
                ("year", models.DateField()),
                (
                    "created_at",
                    models.DateTimeField(
                        db_index=True,
                        default=django.utils.timezone.now,
                        verbose_name="Created datetime",
                    ),
                ),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("is_busy", models.BooleanField(default=False)),
                (
                    "driver",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="vehicles",
                        to="driverpassen.driver",
                    ),
                ),
            ],
            options={
                "verbose_name": "Vehicle",
                "verbose_name_plural": "Vehicles",
                "db_table": "binary_database_files_vehicle",
            },
        ),
        migrations.CreateModel(
            name="Ride",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("pickup_location", models.CharField(max_length=255)),
                ("dropoff_location", models.CharField(max_length=255)),
                ("fare", models.DecimalField(decimal_places=2, max_digits=10)),
                (
                    "status",
                    models.CharField(
                        choices=[
                            ("requested", "Requested"),
                            ("accepted", "Accepted"),
                            ("completed", "Completed"),
                            ("canceled", "Canceled"),
                        ],
                        default="requested",
                        max_length=10,
                    ),
                ),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "driver",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        to="driverpassen.driver",
                    ),
                ),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        to="driverpassen.user",
                    ),
                ),
            ],
        ),
        migrations.CreateModel(
            name="DriverLicense",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "created_at",
                    models.DateTimeField(
                        db_index=True,
                        default=django.utils.timezone.now,
                        verbose_name="Created datetime",
                    ),
                ),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "driver",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        to="driverpassen.driver",
                    ),
                ),
            ],
            options={
                "verbose_name": "Driver License",
                "verbose_name_plural": "Driver Licenses",
                "db_table": "binary_database_files_driver_license",
            },
        ),
        migrations.CreateModel(
            name="VehicleLicense",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "created_at",
                    models.DateTimeField(
                        db_index=True,
                        default=django.utils.timezone.now,
                        verbose_name="Created datetime",
                    ),
                ),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "vehicle",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        to="driverpassen.vehicle",
                    ),
                ),
            ],
            options={
                "verbose_name": "Vehicle License",
                "verbose_name_plural": "Vehicle Licenses",
                "db_table": "binary_database_files_vehicle_license",
                "ordering": ["-created_at"],
                "indexes": [
                    models.Index(
                        fields=["created_at"], name="binary_data_created_854dba_idx"
                    )
                ],
            },
        ),
        migrations.AddConstraint(
            model_name="vehiclelicense",
            constraint=models.UniqueConstraint(
                fields=("vehicle", "created_at"), name="unique_vehicle_license"
            ),
        ),
        migrations.AlterUniqueTogether(
            name="vehiclelicense",
            unique_together={("vehicle", "created_at")},
        ),
    ]
