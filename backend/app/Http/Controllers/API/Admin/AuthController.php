<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{


public function login(Request $request)
{
    $validator = Validator::make($request->all(), [
        'email' => 'required|email',
        'password' => 'required|string|min:6',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'message' => 'Erreur de validation',
            'errors' => $validator->errors()
        ], 422);
    }

    // Nettoyage email (important)
    $credentials = [
        'email' => trim(strtolower($request->email)),
        'password' => $request->password,
    ];

    if (! Auth::attempt($credentials)) {
        return response()->json([
            'message' => 'Email ou mot de passe incorrect'
        ], 401);
    }

    $user = Auth::user();

    // Vérification rôle admin
    if (trim($user->role) !== 'admin') {
        Auth::logout();
        return response()->json([
            'message' => 'Accès refusé'
        ], 403);
    }

    $token = $user->createToken('admin_token')->plainTextToken;

    return response()->json([
        'message' => 'Connexion réussie',
        'token' => $token,
        'user' => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
        ],
    ], 200);
}


    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Déconnecté avec succès',
        ]);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }
}
