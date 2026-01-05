<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\Rental;
use App\Models\Caftan;
use Illuminate\Http\Request;

class AdminRentalController extends Controller
{
    public function index(Request $request)
    {
        $query = Rental::with(['client', 'caftan']);

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        if ($paymentStatus = $request->input('payment_status')) {
            $query->where('payment_status', $paymentStatus);
        }

        // Filtrer par caftan spécifique si fourni
        if ($caftanId = $request->input('caftan_id')) {
            $query->where('caftan_id', $caftanId);
        }

        // Filtrer par chevauchement de dates si start_date et end_date sont fournis
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');
        if ($startDate && $endDate) {
            $query->where(function ($q) use ($startDate, $endDate) {
                $q->whereBetween('start_date', [$startDate, $endDate])
                    ->orWhereBetween('end_date', [$startDate, $endDate])
                    ->orWhere(function ($q2) use ($startDate, $endDate) {
                        $q2->where('start_date', '<=', $startDate)
                            ->where('end_date', '>=', $endDate);
                    });
            });
        }

        $rentals = $query->orderByDesc('start_date')->paginate(15);

        return response()->json($rentals);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'client_id' => 'required|exists:clients,id',
            'caftan_id' => 'required|exists:caftans,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'total_days' => 'required|integer|min:1',
            'total_price' => 'required|numeric|min:0',
            'deposit_amount' => 'nullable|numeric|min:0',
            'status' => 'required|in:active,returned,cancelled',
            'payment_status' => 'required|in:pending,partial,paid',
            'notes' => 'nullable|string',
        ]);

        $data['created_by'] = $request->user()->id;

        $rental = Rental::create($data);

        if ($rental->status === 'active') {
            $caftan = Caftan::find($rental->caftan_id);
            if ($caftan) {
                $caftan->is_available = false;
                $caftan->save();
            }
        }

        return response()->json($rental, 201);
    }

    public function show($id)
    {
        $rental = Rental::with(['client', 'caftan', 'createdBy'])->findOrFail($id);

        return response()->json($rental);
    }

    public function update(Request $request, $id)
    {
        $rental = Rental::findOrFail($id);

        $data = $request->validate([
            'client_id' => 'sometimes|required|exists:clients,id',
            'caftan_id' => 'sometimes|required|exists:caftans,id',
            'start_date' => 'sometimes|required|date',
            'end_date' => 'sometimes|required|date|after_or_equal:start_date',
            'total_days' => 'sometimes|required|integer|min:1',
            'total_price' => 'sometimes|required|numeric|min:0',
            'deposit_amount' => 'nullable|numeric|min:0',
            'status' => 'sometimes|required|in:active,returned,cancelled',
            'payment_status' => 'sometimes|required|in:pending,partial,paid',
            'notes' => 'nullable|string',
        ]);

        $oldStatus = $rental->status;

        $rental->update($data);

        if (array_key_exists('status', $data) && $oldStatus !== $rental->status) {
            $caftan = Caftan::find($rental->caftan_id);
            if ($caftan) {
                if ($rental->status === 'active') {
                    $caftan->is_available = false;
                } elseif (in_array($rental->status, ['returned', 'cancelled'], true)) {
                    $caftan->is_available = true;
                }
                $caftan->save();
            }
        }

        return response()->json($rental);
    }

    public function destroy($id)
    {
        $rental = Rental::findOrFail($id);
        $rental->delete();

        return response()->json(['message' => 'Location supprimée avec succès']);
    }

    public function updateStatus(Request $request, $id)
    {
        $rental = Rental::findOrFail($id);

        $data = $request->validate([
            'status' => 'required|in:active,returned,cancelled',
        ]);

        $oldStatus = $rental->status;

        $rental->update($data);

        if ($oldStatus !== $rental->status) {
            $caftan = Caftan::find($rental->caftan_id);
            if ($caftan) {
                if ($rental->status === 'active') {
                    $caftan->is_available = false;
                } elseif (in_array($rental->status, ['returned', 'cancelled'], true)) {
                    $caftan->is_available = true;
                }
                $caftan->save();
            }
        }

        return response()->json($rental);
    }

    public function updatePayment(Request $request, $id)
    {
        $rental = Rental::findOrFail($id);

        $data = $request->validate([
            'payment_status' => 'required|in:pending,partial,paid',
        ]);

        $rental->update($data);

        return response()->json($rental);
    }
}
