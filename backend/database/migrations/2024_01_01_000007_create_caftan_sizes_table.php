<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('caftan_sizes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('caftan_id')->constrained()->onDelete('cascade');
            $table->foreignId('size_id')->constrained()->onDelete('cascade');
            $table->integer('quantity')->default(1);
            $table->timestamps();
            $table->unique(['caftan_id', 'size_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('caftan_sizes');
    }
};
