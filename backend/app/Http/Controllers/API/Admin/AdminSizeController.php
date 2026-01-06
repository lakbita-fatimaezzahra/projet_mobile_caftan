<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\Size;
use Illuminate\Http\Request;

class AdminSizeController extends Controller
{
    public function index()
    {
        return response()->json(Size::orderBy('name')->get());
    }

    public function show($id)
    {
        $size = Size::findOrFail($id);

        return response()->json($size);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:50',
            'description' => 'nullable|string',
        ]);

        $size = Size::create($data);

        return response()->json($size, 201);
    }

    public function update(Request $request, $id)
    {
        $size = Size::findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|required|string|max:50',
            'description' => 'nullable|string',
        ]);

        $size->update($data);

        return response()->json($size);
    }

    public function destroy($id)
    {
        $size = Size::findOrFail($id);
        $size->delete();

        return response()->json(['message' => 'Taille supprimée avec succès']);
    }
}
