<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\Color;
use Illuminate\Http\Request;

class AdminColorController extends Controller
{
    public function index()
    {
        return response()->json(Color::orderBy('name')->get());
    }

    public function show($id)
    {
        $color = Color::findOrFail($id);

        return response()->json($color);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'hex_code' => 'required|string|size:7',
        ]);

        $color = Color::create($data);

        return response()->json($color, 201);
    }

    public function update(Request $request, $id)
    {
        $color = Color::findOrFail($id);

        $data = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'hex_code' => 'sometimes|required|string|size:7',
        ]);

        $color->update($data);

        return response()->json($color);
    }

    public function destroy($id)
    {
        $color = Color::findOrFail($id);
        $color->delete();

        return response()->json(['message' => 'Couleur supprimée avec succès']);
    }
}
