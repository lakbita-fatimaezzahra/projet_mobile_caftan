<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

class Rental extends Model
{
    use HasFactory;

    protected $fillable = [
        'client_id',
        'caftan_id',
        'size_id',
        'start_date',
        'end_date',
        'total_days',
        'total_price',
        'deposit_amount',
        'status',
        'payment_status',
        'notes',
        'created_by',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    public function client()
    {
        return $this->belongsTo(Client::class);
    }

    public function caftan()
    {
        return $this->belongsTo(Caftan::class);
    }

    public function size()
    {
        return $this->belongsTo(Size::class);
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function getTotalDaysAttribute()
    {
        if ($this->start_date && $this->end_date) {
            return $this->start_date->diffInDays($this->end_date) + 1;
        }

        return null;
    }
}
