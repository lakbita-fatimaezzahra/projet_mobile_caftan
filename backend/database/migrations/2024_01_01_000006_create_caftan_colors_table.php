<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('caftan_colors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('caftan_id')->constrained()->onDelete('cascade');
            $table->foreignId('color_id')->constrained()->onDelete('cascade');
            $table->timestamps();
            $table->unique(['caftan_id', 'color_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('caftan_colors');
    }
};
