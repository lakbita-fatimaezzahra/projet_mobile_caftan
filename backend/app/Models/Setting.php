<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use HasFactory;

    protected $fillable = [
        'company_name',
        'phone',
        'email',
        'address',
        'whatsapp',
        'facebook',
        'instagram',
        'description',
        'logo',
    ];
}
