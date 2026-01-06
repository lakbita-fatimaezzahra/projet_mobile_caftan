<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\Client;
use Illuminate\Http\Request;

class AdminClientController extends Controller
{
    public function index(Request $request)
    {
        $query = Client::withCount('rentals')
            ->orderBy('name');

        if ($cin = $request->input('cin')) {
            $query->where('cin', $cin);
        }

        $clients = $query->paginate(20);

        return response()->json($clients);
    }

    public function show($id)
    {
        $client = Client::with('rentals.caftan', 'rentals.size')
            ->findOrFail($id);

        return response()->json($client);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'cin' => 'nullable|string|max:50|unique:clients,cin',
            'phone' => 'required|string|max:50',
            'email' => 'nullable|email',
            'address' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        $client = Client::create($data);

        return response()->json($client, 201);
    }

    public function update(Request $request, $id)
    {
        $client = Client::findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'cin' => 'nullable|string|max:50|unique:clients,cin,' . $id,
            'phone' => 'sometimes|required|string|max:50',
            'email' => 'nullable|email',
            'address' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        $client->update($data);

        return response()->json($client);
    }

    public function destroy($id)
    {
        $client = Client::findOrFail($id);
        $client->delete();

        return response()->json(['message' => 'Client supprimé avec succès']);
    }
}
