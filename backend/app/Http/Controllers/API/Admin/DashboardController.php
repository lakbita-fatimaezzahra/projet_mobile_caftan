<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\Caftan;
use App\Models\Client;
use App\Models\Rental;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        $totalCaftans = Caftan::count();
        $availableCaftans = Caftan::where('is_available', true)->count();
        $activeRentals = Rental::where('status', 'active')->count();
        $clientsCount = Client::count();

        $startOfMonth = Carbon::now()->startOfMonth();
        $endOfMonth = Carbon::now()->endOfMonth();

        $monthlyRevenue = Rental::whereBetween('start_date', [$startOfMonth, $endOfMonth])
            ->sum('total_price');

        return response()->json([
            'total_caftans' => $totalCaftans,
            'available_caftans' => $availableCaftans,
            'active_rentals' => $activeRentals,
            'clients_count' => $clientsCount,
            'monthly_revenue' => $monthlyRevenue,
        ]);
    }
}
