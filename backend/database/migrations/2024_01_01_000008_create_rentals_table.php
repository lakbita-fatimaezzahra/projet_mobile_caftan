<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rentals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')->constrained()->onDelete('cascade');
            $table->foreignId('caftan_id')->constrained()->onDelete('cascade');
            $table->foreignId('size_id')->constrained();
            $table->date('start_date');
            $table->date('end_date');
            $table->integer('total_days');
            $table->decimal('total_price', 10, 2);
            $table->decimal('deposit_amount', 10, 2)->default(0);
            $table->enum('status', ['active', 'returned', 'cancelled'])->default('active');
            $table->enum('payment_status', ['pending', 'partial', 'paid'])->default('pending');
            $table->text('notes')->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rentals');
    }
};
