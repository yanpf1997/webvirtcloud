# Generated by Django 2.2.20 on 2021-05-31 08:16

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('logs', '0002_auto_20200615_0637'),
    ]

    operations = [
        migrations.AddField(
            model_name='logs',
            name='host',
            field=models.CharField(default='-', max_length=50, verbose_name='host'),
        ),
    ]
