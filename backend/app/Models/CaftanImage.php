<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CaftanImage extends Model
{
    use HasFactory;

    protected $fillable = [
        'caftan_id',
        'image_path',
        'is_primary',
        'order',
    ];

    public function caftan()
    {
        return $this->belongsTo(Caftan::class);
    }
}
