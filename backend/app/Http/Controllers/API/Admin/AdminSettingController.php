<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class AdminSettingController extends Controller
{
    public function show()
    {
        $setting = Setting::first();

        return response()->json($setting);
    }

    public function update(Request $request)
    {
        $data = $request->validate([
            'company_name' => 'required|string|max:255',
            'phone' => 'required|string|max:50',
            'email' => 'required|email',
            'address' => 'required|string',
            'whatsapp' => 'nullable|string',
            'facebook' => 'nullable|string',
            'instagram' => 'nullable|string',
            'description' => 'nullable|string',
            'logo' => 'nullable|string',
        ]);

        $setting = Setting::first();

        if (! $setting) {
            $setting = Setting::create($data);
        } else {
            $setting->update($data);
        }

        return response()->json($setting);
    }
}
