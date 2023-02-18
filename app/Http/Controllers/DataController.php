<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Data;

class DataController extends Controller
{
    public function index() {
        $datas = Data::all();

        return view('index')
        ->with('datas', $datas);
    }

    public function create(Request $request) {
        switch ($request->method()) {
            case 'POST':
                $data = new Data;
                $data->title = $request->title;
                $data->description = $request->description;
                $data->save();

                return redirect()
                ->route('index');
                break;

            case 'GET':
                return view('create');
                break;
            default:
                return redirect()
                ->route('index');
                break;
        }
    }

    public function update(Request $request, $id) {
        switch ($request->method()) {
            case 'POST':
                $data = Data::find($request->id);
                $data->title = $request->title;
                $data->description = $request->description;
                $data->save();

                return redirect()
                ->route('index');
                break;

            case 'GET':
                $data = Data::find($request->id);
                return view('edit')
                ->with('data', $data);
                break;
            default:
                return redirect()
                ->route('index');
                break;
        }
    }

    public function delete($id) {
        $data = Data::find($id);
        $data->delete();

        return redirect()
        ->route('index');
    }
}
